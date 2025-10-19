import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';
import '../../widgets/therapy_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  String? _userName;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Dashboard data
  Map<String, dynamic>? _dashboardData;
  bool _isDashboardLoading = true;
  String? _dashboardError;

  // Tasks data
  List<dynamic> _todayTasks = [];
  int _completedTasksCount = 0;
  int _pendingTasksCount = 0;
  bool _isTasksLoading = true;


  // Featured blogs
  List<dynamic> _featuredBlogs = [];
  bool _blogsLoading = true;

  final Color primaryColor = const Color(0xFF8159A8);

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
    _loadAllData();
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
    if (mounted) {
      setState(() {
        _userName = name ?? 'User';
      });
    }
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadDashboardData(),
      _loadTodayTasks(),
      _loadFeaturedBlogs(),
    ]);
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isDashboardLoading = true;
      _dashboardError = null;
    });

    try {
      final result = await ApiService.getDashboardData();
      if (result['success'] == true && mounted) {
        setState(() {
          _dashboardData = result['data'];
          _isDashboardLoading = false;
        });
      } else {
        setState(() {
          _dashboardError = result['message'] ?? 'Failed to load dashboard data';
          _isDashboardLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dashboardError = 'Error: $e';
          _isDashboardLoading = false;
        });
      }
    }
  }

  Future<void> _loadTodayTasks() async {
    setState(() {
      _isTasksLoading = true;
    });

    try {
      final result = await ApiService.getTodayTasks();
      if (result['success'] == true && mounted) {
        setState(() {
          _todayTasks = (result['tasks'] ?? []).take(3).toList();
          _completedTasksCount = result['completed'] ?? 0;
          _pendingTasksCount = result['pending'] ?? 0;
          _isTasksLoading = false;
        });
      } else {
        setState(() {
          _isTasksLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTasksLoading = false;
        });
      }
    }
  }

  Future<void> _loadFeaturedBlogs() async {
    setState(() {
      _blogsLoading = true;
    });

    try {
      final result = await ApiService.getFeaturedBlogs(limit: 2);
      if (result['success'] == true && mounted) {
        setState(() {
          _featuredBlogs = result['blogs'] ?? [];
          _blogsLoading = false;
        });
      } else {
        setState(() {
          _blogsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _blogsLoading = false;
        });
      }
    }
  }

  Future<void> _toggleTaskStatus(String taskId, String currentStatus) async {
    try {
      final newStatus = currentStatus == 'COMPLETED' ? 'PENDING' : 'COMPLETED';
      final response = await ApiService.authenticatedRequest(
        'PATCH',
        '/api/mobile/task/$taskId',
        body: {'status': newStatus},
      );

      if (response.statusCode == 200) {
        _loadTodayTasks();
      }
    } catch (e) {
      print('Error toggling task: $e');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: const TherapyAppBar(
        title: 'Dashboard',
        height: 56,
        backgroundColor: Color(0xFFFAFAFA),
      ),
      bottomNavigationBar: MobileNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/appointments');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/task_dashboard');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/choose_therapist');
          }
        },
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(),
                  const SizedBox(height: 24),
                  _buildStatsSection(),
                  const SizedBox(height: 24),
                  _buildNextAppointmentSection(),
                  const SizedBox(height: 24),
                  _buildRelaxationSection(),
                  const SizedBox(height: 24),
                  _buildTodayTasksSection(),
                  const SizedBox(height: 24),
                  _buildFeaturedArticlesSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${_userName ?? 'User'}!',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 28,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ready to spark your focus today?',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final stats = _dashboardData?['stats'];
    final upcomingSessions = stats?['upcomingSessions'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _ModernStatCard(
            icon: Icons.event_outlined,
            title: 'Sessions',
            value: upcomingSessions.toString(),
            subtitle: 'Upcoming',
            color: primaryColor,
            isLoading: _isDashboardLoading,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ModernStatCard(
            icon: Icons.check_circle_outline,
            title: 'Tasks',
            value: _completedTasksCount.toString(),
            subtitle: 'Completed Today',
            color: const Color(0xFF10B981),
            isLoading: _isTasksLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildNextAppointmentSection() {
    if (_isDashboardLoading) {
      return _buildLoadingCard(height: 140);
    }

    final nextSession = _dashboardData?['stats']?['nextSession'];

    if (nextSession == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Next Appointment',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 48,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No upcoming appointments',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/choose_therapist');
                  },
                  child: const Text(
                    'Book a Session',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final scheduledAt = DateTime.tryParse(nextSession['scheduledAt'] ?? '');
    final therapistName = nextSession['therapistName'] ?? 'Your Therapist';
    final sessionType = (nextSession['type'] ?? 'SESSION')
        .toString()
        .toLowerCase()
        .replaceAll('_', ' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Next Appointment',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/appointments');
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor,
                        primaryColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        therapistName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sessionType,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (scheduledAt != null)
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${DateFormat('MMM d, y').format(scheduledAt)} at ${DateFormat('h:mm a').format(scheduledAt)}',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelaxationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Relaxation & Focus',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _RelaxationCard(
                icon: Icons.air_outlined,
                title: 'Breathing',
                description: 'Guided exercises',
                color: const Color(0xFF06B6D4),
                onTap: () {
                  Navigator.pushNamed(context, '/relaxation');
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _RelaxationCard(
                icon: Icons.music_note_outlined,
                title: 'Music',
                description: 'Calming sounds',
                color: primaryColor,
                onTap: () {
                  Navigator.pushNamed(context, '/relaxation');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today\'s Tasks',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.3,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/task_dashboard');
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              if (_isTasksLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: Color(0xFF8159A8),
                    ),
                  ),
                )
              else if (_todayTasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: 48,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No tasks for today',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: _TaskSummaryChip(
                        icon: Icons.pending_outlined,
                        label: 'Pending',
                        count: _pendingTasksCount,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TaskSummaryChip(
                        icon: Icons.check_circle_outline,
                        label: 'Completed',
                        count: _completedTasksCount,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 12),
                ..._todayTasks.map((task) {
                  final title = task['title'] ?? 'Untitled Task';
                  final status = task['status'] ?? 'PENDING';
                  final isCompleted = status == 'COMPLETED';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _toggleTaskStatus(task['id'], status);
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isCompleted
                                    ? const Color(0xFF10B981)
                                    : Colors.grey[400]!,
                                width: 2,
                              ),
                              color: isCompleted
                                  ? const Color(0xFF10B981)
                                  : Colors.transparent,
                            ),
                            child: isCompleted
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              color: isCompleted
                                  ? Colors.grey[400]
                                  : const Color(0xFF1A1A1A),
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              fontWeight: isCompleted
                                  ? FontWeight.w400
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedArticlesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Featured Articles',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.3,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/blog_list');
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _blogsLoading
            ? _buildLoadingCard(height: 140)
            : _featuredBlogs.isEmpty
                ? Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'No featured articles yet',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _featuredBlogs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, idx) {
                        final blog = _featuredBlogs[idx];
                        final String title = blog['title'] ?? 'Untitled';
                        final String? imageUrl = blog['imageUrl'];

                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/blog_detail',
                              arguments: {'blogId': blog['id'].toString()},
                            );
                          },
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  if (imageUrl != null && imageUrl.isNotEmpty)
                                    Image.memory(
                                      base64Decode(imageUrl.split(',')[1]),
                                      width: 200,
                                      height: 140,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: primaryColor.withOpacity(0.1),
                                          child: Icon(
                                            Icons.article,
                                            size: 48,
                                            color: primaryColor,
                                          ),
                                        );
                                      },
                                    )
                                  else
                                    Container(
                                      width: 200,
                                      height: 140,
                                      color: primaryColor.withOpacity(0.1),
                                      child: Icon(
                                        Icons.article,
                                        size: 48,
                                        color: primaryColor,
                                      ),
                                    ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    right: 12,
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ],
    );
  }

  Widget _buildLoadingCard({double height = 100}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      ),
    );
  }
}

class _ModernStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final bool isLoading;

  const _ModernStatCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isLoading
          ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF8159A8),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
    );
  }
}

class _TaskSummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _TaskSummaryChip({
    Key? key,
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: color,
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
}

class _RelaxationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _RelaxationCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
