import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';

class CompletedTasksPage extends StatefulWidget {
  const CompletedTasksPage({Key? key}) : super(key: key);

  @override
  State<CompletedTasksPage> createState() => _CompletedTasksPageState();
}

class _CompletedTasksPageState extends State<CompletedTasksPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  bool _isCalendarExpanded = false;

  // Sample completed tasks data - in real app, this would come from your database
  final Map<DateTime, List<Map<String, dynamic>>> _completedTasks = {
    // Existing dummy data for 2024
    DateTime(2025, 7, 1): [
      {
        'title': 'Website Redesign Review',
        'category': 'UI/UX Design',
        'completedAt': '2:30 PM',
        'priority': 'high',
        'duration': '2h 45m',
      },
      {
        'title': 'Client Meeting Preparation',
        'category': 'Project Management',
        'completedAt': '4:15 PM',
        'priority': 'medium',
        'duration': '1h 30m',
      },
      {
        'title': 'Code Review Session',
        'category': 'Development',
        'completedAt': '6:00 PM',
        'priority': 'high',
        'duration': '3h 15m',
      },
    ],
    DateTime(2025, 7, 2): [
      {
        'title': 'Mobile App Testing',
        'category': 'App Development',
        'completedAt': '11:30 AM',
        'priority': 'medium',
        'duration': '2h 20m',
      },
      {
        'title': 'Brand Identity Research',
        'category': 'Branding',
        'completedAt': '3:45 PM',
        'priority': 'low',
        'duration': '1h 45m',
      },
    ],
    DateTime(2025, 7, 3): [
      {
        'title': 'Team Standup Meeting',
        'category': 'Project Management',
        'completedAt': '10:00 AM',
        'priority': 'medium',
        'duration': '45m',
      },
      {
        'title': 'Database Optimization',
        'category': 'Development',
        'completedAt': '2:30 PM',
        'priority': 'high',
        'duration': '4h 15m',
      },
      {
        'title': 'User Interface Design',
        'category': 'UI/UX Design',
        'completedAt': '5:20 PM',
        'priority': 'high',
        'duration': '3h 30m',
      },
    ],
    DateTime(2025, 7, 4): [
      {
        'title': 'API Documentation',
        'category': 'Development',
        'completedAt': '1:15 PM',
        'priority': 'medium',
        'duration': '2h 30m',
      },
    ],
    DateTime(2025, 7, 14): [
      {
        'title': 'Current Day Task 1',
        'category': 'Testing',
        'completedAt': '9:00 AM',
        'priority': 'high',
        'duration': '1h 00m',
      },
      {
        'title': 'Current Day Task 2',
        'category': 'Demo',
        'completedAt': '11:30 AM',
        'priority': 'medium',
        'duration': '2h 30m',
      },
    ],
    // New dummy data for current date (July 17, 2025)
    DateTime(2025, 7, 17): [
      {
        'title': 'Current Day Task 1',
        'category': 'Testing',
        'completedAt': '9:00 AM',
        'priority': 'high',
        'duration': '1h 00m',
      },
      {
        'title': 'Current Day Task 2',
        'category': 'Demo',
        'completedAt': '11:30 AM',
        'priority': 'medium',
        'duration': '2h 30m',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getTasksForDay(DateTime day) {
    return _completedTasks[DateTime(day.year, day.month, day.day)] ?? [];
  }

  bool _hasTasksForDay(DateTime day) {
    return _completedTasks.containsKey(DateTime(day.year, day.month, day.day));
  }

  String _getTotalDuration(List<Map<String, dynamic>> tasks) {
    if (tasks.isEmpty) return '0h 0m';

    int totalMinutes = 0;
    for (var task in tasks) {
      String duration = task['duration'] ?? '0m';
      RegExp regExp = RegExp(r'(\d+)h|(\d+)m');
      Iterable<RegExpMatch> matches = regExp.allMatches(duration);

      for (RegExpMatch match in matches) {
        if (match.group(1) != null) {
          totalMinutes += int.parse(match.group(1)!) * 60;
        }
        if (match.group(2) != null) {
          totalMinutes += int.parse(match.group(2)!);
        }
      }
    }

    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final days = <DateTime>[];

    for (int i = 0; i < lastDay.day; i++) {
      days.add(DateTime(firstDay.year, firstDay.month, firstDay.day + i));
    }

    return days;
  }

  List<DateTime> _getWeekDays() {
    final today = DateTime.now();
    final currentWeekDay = today.weekday;
    final startOfWeek = today.subtract(Duration(days: currentWeekDay - 1));

    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  String _getMonthName(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[date.month - 1];
  }

  String _getDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final tasksForSelectedDay = _getTasksForDay(_selectedDay);

    // Ensure _focusedMonth is always valid (allow navigation to any year/month)
    // Add year navigation buttons to calendar header

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE9ECEF), width: 1),
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF1A1A1A),
              size: 20,
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completed Tasks',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Track your achievements',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _isCalendarExpanded = !_isCalendarExpanded;
                });
              },
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
                ),
                child: Icon(
                  _isCalendarExpanded ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MobileNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/appointments');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/choose_therapist');
          }
        },
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Calendar Section
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
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
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  // Go to previous year
                                  _focusedMonth = DateTime(
                                    _focusedMonth.year - 1,
                                    _focusedMonth.month,
                                  );
                                });
                              },
                              icon: const Icon(
                                Icons.keyboard_double_arrow_left,
                                color: Color(0xFF8159A8),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  // Go to previous month
                                  _focusedMonth = DateTime(
                                    _focusedMonth.year,
                                    _focusedMonth.month - 1,
                                  );
                                });
                              },
                              icon: const Icon(
                                Icons.chevron_left,
                                color: Color(0xFF8159A8),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_getMonthName(_focusedMonth)} ${_focusedMonth.year}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  // Go to next month
                                  _focusedMonth = DateTime(
                                    _focusedMonth.year,
                                    _focusedMonth.month + 1,
                                  );
                                });
                              },
                              icon: const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF8159A8),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  // Go to next year
                                  _focusedMonth = DateTime(
                                    _focusedMonth.year + 1,
                                    _focusedMonth.month,
                                  );
                                });
                              },
                              icon: const Icon(
                                Icons.keyboard_double_arrow_right,
                                color: Color(0xFF8159A8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Calendar Grid
                    if (_isCalendarExpanded)
                      _buildMonthView()
                    else
                      _buildWeekView(),
                  ],
                ),
              ),

              // Summary Section
              if (tasksForSelectedDay.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(246, 147, 104, 191),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(
                        '${tasksForSelectedDay.length}',
                        'Tasks Completed',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _buildSummaryItem(
                        _getTotalDuration(tasksForSelectedDay),
                        'Total Time',
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Tasks List
              Expanded(
                child: tasksForSelectedDay.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: tasksForSelectedDay.length,
                        itemBuilder: (context, index) {
                          final task = tasksForSelectedDay[index];
                          return _buildCompletedTaskItem(task);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekView() {
    final weekDays = _getWeekDays();

    return Column(
      children: [
        // Week day headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDays.map((day) {
            return Text(
              _getDayName(day),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // Week days
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDays.map((day) {
            return _buildDayItem(day);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMonthView() {
    final daysInMonth = _getDaysInMonth(_focusedMonth);
    final firstDayWeekday = daysInMonth.first.weekday;

    return Column(
      children: [
        // Month day headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((
            day,
          ) {
            return Text(
              day,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // Month days grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: daysInMonth.length + (firstDayWeekday - 1),
          itemBuilder: (context, index) {
            if (index < firstDayWeekday - 1) {
              return const SizedBox.shrink();
            }

            final dayIndex = index - (firstDayWeekday - 1);
            final day = daysInMonth[dayIndex];

            return _buildDayItem(day);
          },
        ),
      ],
    );
  }

  Widget _buildDayItem(DateTime day) {
    final isSelected =
        _selectedDay.year == day.year &&
        _selectedDay.month == day.month &&
        _selectedDay.day == day.day;
    final isToday =
        DateTime.now().year == day.year &&
        DateTime.now().month == day.month &&
        DateTime.now().day == day.day;
    final hasTasks = _hasTasksForDay(day);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = day;
        });
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8159A8)
              : isToday
              ? const Color(0xFF8159A8).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isSelected
              ? Border.all(color: const Color(0xFF8159A8), width: 1)
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : isToday
                      ? const Color(0xFF8159A8)
                      : const Color(0xFF1A1A1A),
                ),
              ),
            ),
            if (hasTasks)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF8159A8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF8159A8),
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No completed tasks',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No tasks were completed on ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTaskItem(Map<String, dynamic> task) {
    Color priorityColor;
    switch (task['priority']) {
      case 'high':
        priorityColor = const Color(0xFFEF4444);
        break;
      case 'medium':
        priorityColor = const Color(0xFFF59E0B);
        break;
      case 'low':
        priorityColor = const Color(0xFF10B981);
        break;
      default:
        priorityColor = const Color(0xFF6B7280);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF10B981),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'],
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task['category'],
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Completed: ${task['completedAt']}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Duration: ${task['duration']}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF8159A8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
