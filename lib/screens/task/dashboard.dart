import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('name') ?? 'Bruce';
    });
  }

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
              bottom: BorderSide(
                color: Color(0xFFE9ECEF),
                width: 1,
              ),
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Container(
            width: 44,
            height: 44,
            
          
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, ${_userName ?? 'Bruce'}! 👋',
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
                border: Border.all(
                  color: const Color(0xFFE9ECEF),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF6B7280),
                size: 20,
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
                      color: const Color(0xFF8159A8),
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
                              child: _buildOverviewItem('8', 'Assigned Today'),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            Expanded(
                              child: _buildOverviewItem('5', 'Completed'),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            Expanded(
                              child: _buildOverviewItem('3', 'Pending'),
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
                            // Navigate to add task page
                            Navigator.pushNamed(context, '/add_task');
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
                            // Navigate to pomodoro timer
                            Navigator.pushNamed(context, '/pomodoro_timer');
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionButton(
                          'Completed Tasks',
                          Icons.check_circle_outline,
                          const Color(0xFF8159A8),
                          () {
                            // Navigate to completed tasks
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
                  
                  _buildTaskItem(
                    'Website Redesign Review',
                    'UI/UX Design',
                    'Overdue',
                    'overdue',
                  ),
                  _buildTaskItem(
                    'Client Meeting Preparation',
                    'Project Management',
                    'Overdue',
                    'overdue',
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
                  
                  // Task List
                  _buildTaskItem(
                    'Dashboard Analytics Implementation',
                    'Product Design',
                    'Due: 6:00 PM',
                    'high',
                  ),
                  _buildTaskItem(
                    'Mobile App Testing',
                    'App Development',
                    'Due: 4:00 PM',
                    'medium',
                  ),
                  _buildTaskItem(
                    'Brand Identity Research',
                    'Branding',
                    'Due: 8:00 PM',
                    'low',
                  ),
                  _buildTaskItem(
                    'Team Standup Meeting',
                    'Project Management',
                    'Due: 10:00 AM',
                    'medium',
                  ),
                  _buildTaskItem(
                    'Code Review Session',
                    'Development',
                    'Due: 2:00 PM',
                    'high',
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

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
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

  Widget _buildTaskItem(String title, String category, String dueTime, String priority) {
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
                  // Navigate to task details
                  Navigator.pushNamed(context, '/task_details', arguments: {
                    'title': title,
                    'category': category,
                    'dueTime': dueTime,
                    'priority': priority,
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
}