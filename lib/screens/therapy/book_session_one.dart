import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';
import '../../widgets/therapy_appbar.dart';

class BookSessionOnePage extends StatefulWidget {
  @override
  _BookSessionOnePageState createState() => _BookSessionOnePageState();
}

class _BookSessionOnePageState extends State<BookSessionOnePage> {
  final Color primaryPurple = Color(0xff8159a8);
  int selectedDateIndex = 0;
  String selectedTimeSlot = "10:00 AM - 11:00 AM";
  bool showCalendar = false;
  DateTime selectedDate = DateTime(2025, 6, 22);

  final List<Map<String, String>> dates = [
    {"day": "Mon", "date": "22", "month": "Jun", "year": "2025"},
    {"day": "Tue", "date": "23", "month": "Jun", "year": "2025"},
    {"day": "Wed", "date": "24", "month": "Jun", "year": "2025"},
    {"day": "Thu", "date": "25", "month": "Jun", "year": "2025"},
    {"day": "Fri", "date": "26", "month": "Jun", "year": "2025"},
  ];

  final List<String> timeSlots = [
    "9:00 AM - 10:00 AM",
    "10:00 AM - 11:00 AM",
    "11:00 AM - 12:00 AM",
    "12:00 AM - 1:00 PM",
    "1:00 PM - 2:00 PM",
    "2:00 PM - 3:00 PM",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            SizedBox(height: 24), // Gap between screen top and appbar
            TherapyAppBar(),
          ],
        ),
      ),
      bottomNavigationBar: MobileNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return; // Already on this page
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/appointments');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/task_dashboard');
          }
          // Add navigation for other indices if needed
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
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Therapist Photo
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          image: DecorationImage(
                            image: AssetImage('assets/images/logowhite.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.brown.withOpacity(0.8),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      // Therapist Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Dr. Evelyn Reed',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    letterSpacing: 0.5,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 16,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  '4.9',
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
                              'Rs.3000 per session',
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
                ),

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: dates.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, String> dateInfo = entry.value;
                    bool isSelected = index == selectedDateIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDateIndex = index;
                          // Update selected date based on the clicked date
                          selectedDate = DateTime(
                            int.parse(dateInfo['year']!),
                            _getMonthNumber(dateInfo['month']!),
                            int.parse(dateInfo['date']!),
                          );
                        });
                      },
                      child: Container(
                        width: 60,
                        height: 70,
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
                              dateInfo['day']!,
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
                              dateInfo['date']!,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                letterSpacing: 0.5,
                                fontSize: 18,
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 16),

                // View Calendar
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Handle calendar view
                        setState(() {
                          showCalendar = !showCalendar;
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            'View Calendar',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              letterSpacing: 0.5,
                              fontSize: 14,
                              color: primaryPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            showCalendar
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: primaryPurple,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // Calendar View (conditional)
                if (showCalendar) ...[
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: Column(
                      children: [
                        // Calendar Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_getMonthName(selectedDate.month)} ${selectedDate.year}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                letterSpacing: 0.5,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedDate = DateTime(
                                        selectedDate.year,
                                        selectedDate.month - 1,
                                        1,
                                      );
                                    });
                                  },
                                  icon: Icon(
                                    Icons.chevron_left,
                                    color: primaryPurple,
                                  ),
                                  iconSize: 20,
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedDate = DateTime(
                                        selectedDate.year,
                                        selectedDate.month + 1,
                                        1,
                                      );
                                    });
                                  },
                                  icon: Icon(
                                    Icons.chevron_right,
                                    color: primaryPurple,
                                  ),
                                  iconSize: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Calendar Grid
                        _buildCalendarGrid(),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                ],

                // Available Time Slots
                Text(
                  'Available Time Slots ${_getMonthName(selectedDate.month)} ${selectedDate.day}',
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
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: timeSlots.map((timeSlot) {
                    bool isSelected = timeSlot == selectedTimeSlot;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTimeSlot = timeSlot;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryPurple
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? primaryPurple
                                : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            timeSlot,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              letterSpacing: 0.5,
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 24),

                // Booking Summary
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

                SizedBox(height: 12),

                // Session Details Card
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        '${_getDayName(selectedDate.weekday)} ${selectedDate.day}',
                      ),
                      SizedBox(height: 8),
                      _buildDetailRow('Time:', selectedTimeSlot),
                      SizedBox(height: 8),
                      _buildDetailRow('Therapist:', 'Dr. Evelyn Reed'),
                      SizedBox(height: 16),
                      _buildDetailRow('Total Cost:', 'Rs.3000', isPrice: true),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Confirm Booking Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _showBookingConfirmation();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
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

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            letterSpacing: 0.5,
            fontSize: 14,
            color: isPrice ? primaryPurple : Colors.black,
            fontWeight: isPrice ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showBookingConfirmation() {
    showDialog(
      context: context,
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
            'Your session with Dr. Evelyn Reed has been booked for ${_getDayName(selectedDate.weekday)}, ${_getMonthName(selectedDate.month)} ${selectedDate.day} at $selectedTimeSlot.',
            style: TextStyle(fontFamily: 'Poppins',
                letterSpacing: 0.5,fontSize: 16, color: Colors.grey[700]),
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
                child: Text('Done'),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper methods for date formatting and calendar
  String _getMonthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }

  int _getMonthNumber(String month) {
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    return months[month] ?? 1;
  }

  String _getDayName(int weekday) {
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday];
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final startingWeekday = firstDayOfMonth.weekday;

    List<Widget> dayWidgets = [];

    // Add day headers
    const dayHeaders = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (String day in dayHeaders) {
      dayWidgets.add(
        Container(
          height: 30,
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontFamily: 'Poppins',
                letterSpacing: 0.5,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    }

    // Add empty cells for days before the first day of the month
    for (int i = 1; i < startingWeekday; i++) {
      dayWidgets.add(Container());
    }

    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final isSelected = selectedDate.day == day;
      final currentDate = DateTime(selectedDate.year, selectedDate.month, day);

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = currentDate;
              // Update the selectedDateIndex if it matches one of the predefined dates
              for (int i = 0; i < dates.length; i++) {
                if (dates[i]['date'] == day.toString()) {
                  selectedDateIndex = i;
                  break;
                }
              }
            });
          },
          child: Container(
            height: 35,
            decoration: BoxDecoration(
              color: isSelected ? primaryPurple : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                  fontSize: 14,
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: dayWidgets,
    );
  }
}
