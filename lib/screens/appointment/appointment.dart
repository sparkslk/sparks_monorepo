import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';
import 'join_session.dart'; // Import the SessionPage
import 'past_summary.dart'; // Import the SessionSummaryPage

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  bool isUpcomingSelected = true;

  void _toggleTab(bool isUpcoming) {
    setState(() {
      isUpcomingSelected = isUpcoming;
    });
  }

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: const Color(0xFFF6F4FC),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'My Appointments',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Manage your therapy sessions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Modern Toggle Container
                  Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xff8159a8).withOpacity(0.1), // Light purple background
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xff8159a8).withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff8159a8).withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Animated sliding background
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          left: isUpcomingSelected ? 4 : MediaQuery.of(context).size.width * 0.5 - 24,
                          right: isUpcomingSelected ? MediaQuery.of(context).size.width * 0.5 - 24 : 4,
                          top: 4,
                          bottom: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xff8159a8), // Purple background for active tab
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xff8159a8).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Tab buttons
                        Row(
                          children: [
                            // Upcoming Button
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _toggleTab(true),
                                child: Container(
                                  height: 47,
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        child: Icon(
                                          Icons.schedule,
                                          color: isUpcomingSelected
                                              ? Colors.white
                                              : const Color(0xff8159a8),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 200),
                                        style: TextStyle(
                                          color: isUpcomingSelected
                                              ? Colors.white
                                              : const Color(0xff8159a8),
                                          fontFamily: 'Poppins',
                                          fontSize: 15,
                                          fontWeight: isUpcomingSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                        ),
                                        child: const Text('Upcoming'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Past Button
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _toggleTab(false),
                                child: Container(
                                  height: 47,
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        child: Icon(
                                          Icons.history,
                                          color: !isUpcomingSelected
                                              ? Colors.white
                                              : const Color(0xff8159a8),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 200),
                                        style: TextStyle(
                                          color: !isUpcomingSelected
                                              ? Colors.white
                                              : const Color(0xff8159a8),
                                          fontFamily: 'Poppins',
                                          fontSize: 15,
                                          fontWeight: !isUpcomingSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                        ),
                                        child: const Text('Past'),
                                      ),
                                    ],
                                  ),
                                ),
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
            // Content Section
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isUpcomingSelected
                    ? _buildUpcomingAppointments()
                    : _buildPastAppointments(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    final upcomingAppointments = [
      {
        'therapist': 'Dr. Sarah Johnson',
        'specialization': 'Anxiety & Depression',
        'date': 'Today',
        'time': '2:00 PM',
        'type': 'Video Call',
        'avatar': 'SJ',
        'status': 'confirmed',
        'color': const Color(0xFF10B981),
      },
      {
        'therapist': 'Dr. Michael Chen',
        'specialization': 'Cognitive Behavioral Therapy',
        'date': 'Tomorrow',
        'time': '10:30 AM',
        'type': 'In-Person',
        'avatar': 'MC',
        'status': 'confirmed',
        'color': const Color(0xFF10B981),
      },
      {
        'therapist': 'Dr. Emily Rodriguez',
        'specialization': 'Trauma Therapy',
        'date': 'Dec 15',
        'time': '4:00 PM',
        'type': 'Video Call',
        'avatar': 'ER',
        'status': 'pending',
        'color': const Color(0xFFF59E0B),
      },
    ];

    return upcomingAppointments.isEmpty
        ? _buildEmptyState(
      Icons.event_available,
      'No Upcoming Appointments',
      'Schedule your next therapy session',
    )
        : ListView.builder(
      key: const ValueKey('upcoming'),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: upcomingAppointments.length,
      itemBuilder: (context, index) {
        final appointment = upcomingAppointments[index];
        return _buildAppointmentCard(appointment, true);
      },
    );
  }

  Widget _buildPastAppointments() {
    final pastAppointments = [
      {
        'therapist': 'Dr. Sarah Johnson',
        'specialization': 'Anxiety & Depression',
        'date': 'Dec 8',
        'time': '2:00 PM',
        'type': 'Video Call',
        'avatar': 'SJ',
        'status': 'completed',
        'color': const Color(0xFF6B7280),
        'rating': 5,
      },
      {
        'therapist': 'Dr. Michael Chen',
        'specialization': 'Cognitive Behavioral Therapy',
        'date': 'Dec 1',
        'time': '10:30 AM',
        'type': 'In-Person',
        'avatar': 'MC',
        'status': 'completed',
        'color': const Color(0xFF6B7280),
        'rating': 4,
      },
      {
        'therapist': 'Dr. Emily Rodriguez',
        'specialization': 'Trauma Therapy',
        'date': 'Nov 24',
        'time': '4:00 PM',
        'type': 'Video Call',
        'avatar': 'ER',
        'status': 'cancelled',
        'color': const Color(0xFFEF4444),
        'rating': null,
      },
    ];

    return pastAppointments.isEmpty
        ? _buildEmptyState(
      Icons.history,
      'No Past Appointments',
      'Your completed sessions will appear here',
    )
        : ListView.builder(
      key: const ValueKey('past'),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: pastAppointments.length,
      itemBuilder: (context, index) {
        final appointment = pastAppointments[index];
        return _buildAppointmentCard(appointment, false);
      },
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment, bool isUpcoming) {
    return GestureDetector(
      onTap: () {
        // Navigate to session summary for past appointments
        if (!isUpcoming) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SessionSummaryPage(
                appointment: appointment,
              ),
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: appointment['color'],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        appointment['avatar'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment['therapist'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          appointment['specialization'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: appointment['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      appointment['status'],
                      style: TextStyle(
                        color: appointment['color'],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  // Add tap indicator for past appointments
                  if (!isUpcoming) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              // Appointment Details Row
              Row(
                children: [
                  _buildDetailItem(Icons.calendar_today, appointment['date']),
                  const SizedBox(width: 20),
                  _buildDetailItem(Icons.access_time, appointment['time']),
                  const SizedBox(width: 20),
                  _buildDetailItem(
                    appointment['type'] == 'Video Call' ? Icons.videocam : Icons.location_on,
                    appointment['type'],
                  ),
                ],
              ),
              // Rating for past appointments
              if (!isUpcoming && appointment['rating'] != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Rating: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < appointment['rating'] ? Icons.star : Icons.star_border,
                          color: const Color(0xFFF59E0B),
                          size: 16,
                        );
                      }),
                    ),
                    const Spacer(),
                    Text(
                      'Tap for details',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontFamily: 'Poppins',
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
              // Action Buttons for upcoming appointments
              if (isUpcoming && appointment['status'] == 'confirmed') ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/reschedule',
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Reschedule',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to SessionPage with appointment data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SessionPage(
                                appointment: appointment,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff8159a8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Join Session',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              icon,
              size: 60,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/choose_therapist');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Book Appointment',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}