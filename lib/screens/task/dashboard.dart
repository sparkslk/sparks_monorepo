import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';

class TaskDashboardPage extends StatefulWidget {
  const TaskDashboardPage({Key? key}) : super(key: key);

  @override
  State<TaskDashboardPage> createState() => _TaskDashboardPageState();
}

class _TaskDashboardPageState extends State<TaskDashboardPage>
    with TickerProviderStateMixin {
  String? _userName;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  List<Map<String, dynamic>> _yesterdayTasks = [];
  List<Map<String, dynamic>> _todayTasks = [];
  bool _loadingTasks = false;
  String? _taskError;

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
    _loadUserName();
    _fetchTasks();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    String? name;
    final userDataStr = prefs.getString('user_data');
    if (userDataStr != null && userDataStr.isNotEmpty) {
      try {
        final userData = jsonDecode(userDataStr);
        if (userData is Map &&
            userData['name'] != null &&
            userData['name'].toString().trim().isNotEmpty) {
          name = userData['name'];
        }
      } catch (_) {}
    }
    setState(() {
      _userName = name ?? 'User';
    });
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _loadingTasks = true;
      _taskError = null;
    });
    try {
      // Fetch all tasks (all statuses) for accurate overview
      final response = await ApiService.authenticatedRequest(
        'GET',
        '/api/mobile/task',
      );
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      if (response.statusCode == 200 && data['tasks'] is List) {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        _yesterdayTasks = [];
        _todayTasks = [];
        for (final t in data['tasks']) {
          if (t['dueDate'] != null) {
            final due = DateTime.tryParse(t['dueDate']);
            if (due != null) {
              if (due.year == yesterday.year &&
                  due.month == yesterday.month &&
                  due.day == yesterday.day) {
                _yesterdayTasks.add(t);
              } else if (due.year == now.year &&
                  due.month == now.month &&
                  due.day == now.day) {
                _todayTasks.add(t);
              }
            }
          }
        }
        // update daily incomplete schedule using latest tasks (non-blocking)
        NotificationService.I.scheduleDailyIncompleteTasksCheck();
      } else {
        _taskError = data['error'] ?? 'Failed to load tasks.';
      }
    } catch (e) {
      _taskError = 'Error loading tasks: $e';
    }
    setState(() {
      _loadingTasks = false;
    });
  }

  // Removed unused calendar-related state from earlier iterations.

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
          child: Container(width: 44, height: 44),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi,  ${_userName ?? 'User'}! 👋',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.3,
              ),
            ),
            const Text(
              'Let\'s get things done today',
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
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _openNotificationHistory,
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF6B7280),
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's Overview Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(246, 147, 104, 191),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Today\'s Overview',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.today_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildOverviewItem(
                                '${_todayTasks.length}',
                                'Assigned Today',
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            Expanded(
                              child: _buildOverviewItem(
                                '${_todayTasks.where((t) {
                                  final status = t['status'].toString().toUpperCase();
                                  return status == 'COMPLETED' || status == 'DONE' || status == 'FINISHED';
                                }).length}',
                                'Completed',
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            Expanded(
                              child: _buildOverviewItem(
                                '${_todayTasks.where((t) {
                                  final status = t['status'].toString().toUpperCase();
                                  return status == 'PENDING' || status == 'NOT_STARTED' || status == 'IN_PROGRESS';
                                }).length}',
                                'Pending',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Quick Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Add New Task',
                          Icons.add_circle_outline,
                          const Color(0xFF8159A8),
                          () {
                            Navigator.pushNamed(
                              context,
                              '/add_task',
                            ).then((_) => _fetchTasks());
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionButton(
                          'Pomodoro Timer',
                          Icons.timer_outlined,
                          const Color(0xFF8159A8),
                          () {
                            Navigator.pushNamed(context, '/pomodoro_timer');
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionButton(
                          'Completed',
                          Icons.check_circle_outline,
                          const Color(0xFF8159A8),
                          () {
                            Navigator.pushNamed(context, '/completed_tasks');
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Yesterday's Uncompleted Tasks
                  const Text(
                    'Yesterday\'s Tasks',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_loadingTasks)
                    const Center(child: CircularProgressIndicator()),
                  if (_taskError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _taskError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  if (!_loadingTasks &&
                      _yesterdayTasks.isEmpty &&
                      _taskError == null)
                    const Text(
                      'No tasks for yesterday.',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ..._yesterdayTasks.map(
                    (task) => GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/day_tasks',
                          arguments: {'taskId': task['id']},
                        );
                      },
                      child: _buildTaskItem(
                        task['title'] ?? '-',
                        task['category'] ?? '-',
                        task['dueDate'] != null
                            ? 'Due: ${_formatDueTime(task['dueDate'])}'
                            : '',
                        _priorityString(task['priority']),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  // Today's Tasks Section
                  const Text(
                    'Today\'s Tasks',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_loadingTasks)
                    const Center(child: CircularProgressIndicator()),
                  if (_taskError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _taskError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  if (!_loadingTasks &&
                      _todayTasks.isEmpty &&
                      _taskError == null)
                    const Text(
                      'No tasks for today.',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ..._todayTasks.map(
                    (task) => GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/day_tasks',
                          arguments: {'taskId': task['id']},
                        );
                      },
                      child: _buildTaskItem(
                        task['title'] ?? '-',
                        task['category'] ?? '-',
                        task['dueDate'] != null
                            ? 'Due: ${_formatDueTime(task['dueDate'])}'
                            : '',
                        _priorityString(task['priority']),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
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

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
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
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(
    String title,
    String category,
    String dueTime,
    String priority,
  ) {
    Color priorityColor;
    Color cardColor = Colors.white;
    Color textColor = const Color(0xFF1A1A1A);

    switch (priority) {
      case 'overdue':
        priorityColor = const Color(0xFFEF4444);
        cardColor = const Color(0xFFEF4444).withOpacity(0.05);
        textColor = const Color(0xFFEF4444);
        break;
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
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: priority == 'overdue'
              ? const Color(0xFFEF4444).withOpacity(0.3)
              : const Color(0xFFE9ECEF),
          width: 1,
        ),
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
              color: priority == 'overdue'
                  ? const Color(0xFFEF4444).withOpacity(0.1)
                  : const Color(0xFF8159A8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              priority == 'overdue'
                  ? Icons.warning_outlined
                  : Icons.folder_outlined,
              color: priority == 'overdue'
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF8159A8),
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
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: priority == 'overdue'
                        ? const Color(0xFFEF4444).withOpacity(0.8)
                        : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dueTime,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: priority == 'overdue'
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF8159A8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/task_details',
                    arguments: {
                      'title': title,
                      'category': category,
                      'dueTime': dueTime,
                      'priority': priority,
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8159A8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'View More',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: Color(0xFF8159A8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _priorityString(dynamic priority) {
    if (priority == 3) return 'high';
    if (priority == 2) return 'medium';
    if (priority == 1) return 'low';
    return 'low';
  }

  String _formatDueTime(String dueDate) {
    try {
      final dt = DateTime.parse(dueDate);
      final hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (_) {
      return dueDate;
    }
  }

  Future<void> _openNotificationHistory() async {
    final history = await NotificationService.I.fetchHistory();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return _NotificationHistorySheet(
          entries: history,
          onCleared: () async {
            await NotificationService.I.clearHistory();
            if (mounted) Navigator.pop(ctx); // close sheet
          },
        );
      },
    ).then((_) => setState(() {}));
  }
}

class _NotificationHistorySheet extends StatefulWidget {
  final List<Map<String, dynamic>> entries; // already reversed chronologically
  final VoidCallback onCleared;
  const _NotificationHistorySheet({
    required this.entries,
    required this.onCleared,
  });

  @override
  State<_NotificationHistorySheet> createState() =>
      _NotificationHistorySheetState();
}

class _NotificationHistorySheetState extends State<_NotificationHistorySheet> {
  late List<Map<String, dynamic>> _entries;
  @override
  void initState() {
    super.initState();
    _entries = widget.entries;
  }

  IconData _iconFor(String kind) {
    switch (kind) {
      case 'scheduled_15s':
        return Icons.schedule;
      case 'immediate_fallback':
        return Icons.flash_on;
      case 'daily_incomplete':
        return Icons.error_outline;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color _colorFor(String kind) {
    switch (kind) {
      case 'scheduled_15s':
        return const Color(0xFF2563EB);
      case 'immediate_fallback':
        return const Color(0xFFF59E0B);
      case 'daily_incomplete':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF8159A8);
    }
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  void _replay(Map<String, dynamic> entry) async {
    await NotificationService.I.replay(entry);
    final refreshed = await NotificationService.I.fetchHistory();
    if (mounted)
      setState(() {
        _entries = refreshed;
      });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                if (_entries.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dCtx) => AlertDialog(
                          title: const Text('Clear All?'),
                          content: const Text(
                            'Remove all notification history?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dCtx, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(dCtx, true),
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await NotificationService.I.clearHistory();
                        if (mounted)
                          setState(() {
                            _entries = [];
                          });
                      }
                    },
                    child: const Text('Clear All'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: const [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No notifications yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _entries.length,
                  itemBuilder: (ctx, i) {
                    final e = _entries[i];
                    final title = e['title']?.toString() ?? 'Untitled';
                    final body = e['body']?.toString() ?? '';
                    final kind = e['kind']?.toString() ?? 'instant';
                    final createdAt = e['createdAt']?.toString();
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _colorFor(kind).withOpacity(0.15),
                        child: Icon(
                          _iconFor(kind),
                          color: _colorFor(kind),
                          size: 18,
                        ),
                      ),
                      title: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (createdAt != null)
                            Text(
                              _formatTime(createdAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _colorFor(kind).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              kind.replaceAll('_', ' '),
                              style: TextStyle(
                                fontSize: 9,
                                color: _colorFor(kind),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () => _replay(e),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
