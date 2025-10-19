import 'package:flutter/material.dart';
import 'dart:convert';
import '../../widgets/navbar.dart';
import '../../widgets/therapy_appbar.dart';
import '../../services/api_service.dart';

class CompletedTasksPage extends StatefulWidget {
  CompletedTasksPage({Key? key}) : super(key: key);

  @override
  State<CompletedTasksPage> createState() => _CompletedTasksPageState();
}

class _CompletedTasksPageState extends State<CompletedTasksPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: const TherapyAppBar(
        title: 'Completed Tasks',
        showBackButton: true,
      ),
      body: AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : Column(
                    children: [
                      // Calendar
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left),
                                  onPressed: () {
                                    setState(() {
                                      _focusedMonth = DateTime(
                                        _focusedMonth.year,
                                        _focusedMonth.month - 1,
                                      );
                                    });
                                  },
                                ),
                                Text(
                                  '${_getMonthName(_focusedMonth)} ${_focusedMonth.year}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: () {
                                    setState(() {
                                      _focusedMonth = DateTime(
                                        _focusedMonth.year,
                                        _focusedMonth.month + 1,
                                      );
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Toggle calendar view (optional, can be expanded)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isCalendarExpanded = false;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !_isCalendarExpanded
                                          ? const Color(0xFF8159A8)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Week',
                                      style: TextStyle(
                                        color: !_isCalendarExpanded
                                            ? Colors.white
                                            : const Color(0xFF8159A8),
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isCalendarExpanded = true;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _isCalendarExpanded
                                          ? const Color(0xFF8159A8)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Month',
                                      style: TextStyle(
                                        color: _isCalendarExpanded
                                            ? Colors.white
                                            : const Color(0xFF8159A8),
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 300),
                              crossFadeState: _isCalendarExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              firstChild: _buildWeekView(),
                              secondChild: _buildMonthView(),
                            ),
                          ],
                        ),
                      ),
                      // Summary
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(246, 147, 104, 191),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSummaryItem(
                              _getTasksForDay(_selectedDay).length.toString(),
                              'Tasks',
                            ),
                          ],
                        ),
                      ),
                      // Completed tasks list
                      Expanded(
                        child: _getTasksForDay(_selectedDay).isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemCount: _getTasksForDay(_selectedDay).length,
                                itemBuilder: (context, index) {
                                  final task = _getTasksForDay(
                                    _selectedDay,
                                  )[index];
                                  return _buildCompletedTaskItem(task);
                                },
                              ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  bool _isCalendarExpanded = false;

  Map<DateTime, List<Map<String, dynamic>>> _completedTasks = {};
  bool _isLoading = true;
  String? _error;

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
    _fetchCompletedTasks();
  }

  Future<void> _fetchCompletedTasks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Use the correct static method for ApiService
      final response = await ApiService.authenticatedRequest(
        'GET',
        '/api/mobile/task?status=completed',
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List tasks = data['tasks'] ?? [];
        final Map<DateTime, List<Map<String, dynamic>>> grouped = {};
        for (final task in tasks) {
          DateTime completedDate;
          // Use dueDate as completed date if completedAt is not present
          final completedAt = task['completedAt'] ?? task['dueDate'];
          if (completedAt == null) continue;
          if (completedAt is DateTime) {
            completedDate = DateTime(
              completedAt.year,
              completedAt.month,
              completedAt.day,
            );
          } else {
            completedDate = DateTime.parse(completedAt);
            completedDate = DateTime(
              completedDate.year,
              completedDate.month,
              completedDate.day,
            );
          }
          grouped
              .putIfAbsent(completedDate, () => [])
              .add(task as Map<String, dynamic>);
        }
        setState(() {
          _completedTasks = grouped;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load completed tasks.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load completed tasks.';
        _isLoading = false;
      });
    }
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
    // Defensive: fallback values for all fields
    final String title = (task['title'] ?? 'Untitled').toString();
    final String category = (task['category'] ?? 'Uncategorized').toString();
    String completedAtRaw = (task['completedAt'] ?? task['dueDate'] ?? '')
        .toString();
    String completedAt = '';
    if (completedAtRaw.isNotEmpty) {
      try {
        final dt = DateTime.parse(completedAtRaw);
        completedAt =
            '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}, '
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
      } catch (_) {
        completedAt = completedAtRaw;
      }
    }
    final String priority = (task['priority'] ?? 'low')
        .toString()
        .toLowerCase();
    // final String duration = (task['duration'] ?? '0m').toString();

    Color priorityColor;
    switch (priority) {
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
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
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
                      'Completed: $completedAt',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF10B981),
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
