import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/navbar.dart';
import '../../widgets/therapy_appbar.dart';
import '../../services/api_service.dart';
import 'join_session.dart'; // Import the SessionPage
import 'past_summary.dart'; // Import the SessionSummaryPage

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  bool isUpcomingSelected = true;
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> upcomingSessions = [];
  List<Map<String, dynamic>> pastSessions = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Fetch upcoming and past sessions in parallel
      final results = await Future.wait([
        ApiService.getSessions(timeframe: 'upcoming'),
        ApiService.getSessions(timeframe: 'past'),
      ]);

      if (results[0]['success'] && results[1]['success']) {
        setState(() {
          upcomingSessions = _formatSessions(results[0]['sessions'], true);
          pastSessions = _formatSessions(results[1]['sessions'], false);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = results[0]['message'] ?? results[1]['message'] ?? 'Failed to load appointments';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading appointments: $e';
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _formatSessions(List<dynamic> sessions, bool isUpcoming) {
    return sessions.map((session) {
      final therapistName = session['therapist']?['name'] ?? 'Therapist';
      final scheduledAt = DateTime.parse(session['scheduledAt']);
      final status = session['status'] as String;

      return {
        'id': session['id'],
        'therapistId': session['therapistId'],
        'therapist': 'Dr. $therapistName',
        'specialization': 'Cognitive Behavioral Therapy',
        'date': _formatDate(scheduledAt),
        'time': _formatTime(scheduledAt),
        'type': session['type'] ?? 'Video Call',
        'avatar': _getInitials(therapistName),
        'status': _formatStatus(status),
        'color': _getStatusColor(status),
        'duration': session['duration'],
        'sessionNotes': session['sessionNotes'],
        'scheduledAt': scheduledAt,
        'rawStatus': status,
        'canCancel': session['canCancel'] ?? false,
        'rating': null, // TODO: Add rating when available from backend
        'meetingLink': session['meetingLink'], // Include meeting link from API
      };
    }).toList();
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'TH';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final sessionDate = DateTime(date.year, date.month, date.day);

    if (sessionDate == today) {
      return 'Today';
    } else if (sessionDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  String _formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'SCHEDULED':
        return 'confirmed';
      case 'APPROVED':
        return 'confirmed';
      case 'REQUESTED':
        return 'pending';
      case 'COMPLETED':
        return 'completed';
      case 'CANCELLED':
        return 'cancelled';
      case 'NO_SHOW':
        return 'no show';
      default:
        return status.toLowerCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'SCHEDULED':
      case 'APPROVED':
        return const Color(0xFF10B981); // Green
      case 'REQUESTED':
        return const Color(0xFFF59E0B); // Orange
      case 'COMPLETED':
        return const Color(0xFF6B7280); // Grey
      case 'CANCELLED':
      case 'NO_SHOW':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280);
    }
  }

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
            const TherapyAppBar(title: 'Appointments'),
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
              child: isLoading
                  ? _buildLoadingState()
                  : errorMessage != null
                      ? _buildErrorState()
                      : AnimatedSwitcher(
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
    return upcomingSessions.isEmpty
        ? _buildEmptyState(
            Icons.event_available,
            'No Upcoming Appointments',
            'Schedule your next therapy session',
          )
        : ListView.builder(
            key: const ValueKey('upcoming'),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: upcomingSessions.length,
            itemBuilder: (context, index) {
              final appointment = upcomingSessions[index];
              return _buildAppointmentCard(appointment, true);
            },
          );
  }

  Widget _buildPastAppointments() {
    return pastSessions.isEmpty
        ? _buildEmptyState(
            Icons.history,
            'No Past Appointments',
            'Your completed sessions will appear here',
          )
        : ListView.builder(
            key: const ValueKey('past'),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: pastSessions.length,
            itemBuilder: (context, index) {
              final appointment = pastSessions[index];
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
                          Navigator.pushNamed(
                            context,
                            '/reschedule',
                            arguments: appointment,
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

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xff8159a8),
          ),
          SizedBox(height: 16),
          Text(
            'Loading appointments...',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
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
            Text(
              'Failed to Load',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Unable to load appointments',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadAppointments,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff8159a8),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
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
              backgroundColor: const Color(0xff8159a8),
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