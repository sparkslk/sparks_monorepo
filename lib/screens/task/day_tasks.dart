import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';
import '../../widgets/therapy_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'dart:convert';

class CompletedDayTasksPage extends StatefulWidget {
  final String taskId;
  const CompletedDayTasksPage({Key? key, required this.taskId})
    : super(key: key);

  @override
  State<CompletedDayTasksPage> createState() => _CompletedDayTasksPageState();
}

class _CompletedDayTasksPageState extends State<CompletedDayTasksPage>
    with TickerProviderStateMixin {
  String? _userName;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  static const List<String> _statusOptions = [
    'PENDING',
    'IN_PROGRESS',
    'COMPLETED',
    'OVERDUE',
  ];
  String _currentStatus = 'PENDING';

  // Added missing fields for state tracking and saving
  String _originalStatus = 'PENDING';
  String _originalNotes = '';
  bool _isSaving = false;

  Map<String, dynamic>? _taskDetails;
  bool _loadingTask = false;
  String? _taskError;
  DateTime? _completedDateTime;
  String _taskNotes = '';
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Setup animations
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
    });

    _loadUserName();
    _fetchTaskDetails();
  }

  Future<void> _fetchTaskDetails() async {
    setState(() {
      _loadingTask = true;
      _taskError = null;
    });
    try {
      // Fetch task details from backend using the taskId
      final response = await ApiService.authenticatedRequest(
        'GET',
        '/api/mobile/task/${widget.taskId}',
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        if (data['task'] != null) {
          setState(() {
            _taskDetails = data['task'];
            _currentStatus = (_taskDetails!['status'] ?? 'PENDING').toString();
            _taskNotes = _taskDetails!['completionNotes'] ?? '';
            _notesController.text = _taskNotes;
            if (_taskDetails!['completedAt'] != null) {
              _completedDateTime = DateTime.tryParse(
                _taskDetails!['completedAt'],
              );
            } else {
              _completedDateTime = null;
            }
            _originalStatus = _currentStatus;
            _originalNotes = _taskNotes;
          });
        } else {
          setState(() {
            _taskError = 'Task not found.';
          });
        }
      } else {
        setState(() {
          _taskError = 'Failed to load task details.';
        });
      }
    } catch (e) {
      setState(() {
        _taskError = 'Error loading task: $e';
      });
    }
    setState(() {
      _loadingTask = false;
    });
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'COMPLETED':
        return 'Completed';
      case 'PENDING':
        return 'Pending';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'OVERDUE':
        return 'Overdue';
      default:
        return status;
    }
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('name') ?? 'Sandhavi';
    });
  }

  Future<void> _saveTaskData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('task_status', _currentStatus);
    await prefs.setString('task_notes', _taskNotes);
    if (_completedDateTime != null) {
      await prefs.setString(
        'task_completed_time',
        _completedDateTime!.toIso8601String(),
      );
    }
  }

  void _onStatusChanged(String? newStatus) {
    if (newStatus != null) {
      setState(() {
        _currentStatus = newStatus;
        if (newStatus == 'COMPLETED') {
          _completedDateTime = DateTime.now();
        } else {
          _completedDateTime = null;
        }
      });
    }
  }

  bool _canSave() {
    return _currentStatus != _originalStatus || _taskNotes != _originalNotes;
  }

  Future<void> _saveTaskToBackend() async {
    setState(() {
      _isSaving = true;
    });
    try {
      final body = {
        'status': _currentStatus,
        'completionNotes': _taskNotes,
        if (_currentStatus == 'COMPLETED')
          'completedAt': DateTime.now()
              .add(const Duration(hours: 5, minutes: 30))
              .toIso8601String(),
      };
      final response = await ApiService.authenticatedRequest(
        'PUT',
        '/api/mobile/task/${widget.taskId}',
        body: body,
      );
      if (response.statusCode == 200) {
        setState(() {
          _originalStatus = _currentStatus;
          _originalNotes = _taskNotes;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated successfully!'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task: ${response.body}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return const Color(0xFF10B981);
      case 'PENDING':
        return const Color(0xFFF59E0B);
      case 'IN_PROGRESS':
        return const Color(0xFF6366F1);
      case 'OVERDUE':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today, ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${_formatTime(dateTime)}';
    } else {
      return '${_formatDate(dateTime)}, ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _formatDate(DateTime dateTime) {
    const months = [
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
    return '${months[dateTime.month - 1]} ${dateTime.day}';
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const TherapyAppBar(
        title: 'Task Details',
        showBackButton: true,
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
        child: _loadingTask
            ? const Center(child: CircularProgressIndicator())
            : _taskError != null
            ? Center(child: Text(_taskError!))
            : _taskDetails == null
            ? const Center(child: Text('No task details.'))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTaskDetailsCard(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTaskDetailsCard() {
    final task = _taskDetails!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Status Row
          Row(
            children: [
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    height: 1.2,
                  ),
                  child: Text(task['title'] ?? '-'),
                ),
              ),
              const SizedBox(width: 16),
              _buildStatusDropdown(),
            ],
          ),
          const SizedBox(height: 16),
          // Save button
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _canSave() && !_isSaving
                      ? _saveTaskToBackend
                      : null,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_alt),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Description Section
          _buildSection(
            'Description',
            task['description'] ?? 'No description provided.',
            Icons.description_outlined,
          ),

          const SizedBox(height: 20),

          // Tags Section
          _buildTagsSection(task),

          const SizedBox(height: 20),

          // Date and Time Info
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Task Date',
                  task['dueDate'] != null
                      ? _formatDateTime(DateTime.parse(task['dueDate']))
                      : 'No due date',
                  Icons.calendar_today_outlined,
                  const Color(0xFF8159A8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  _currentStatus == 'COMPLETED' ? 'Completed' : 'Status',
                  _currentStatus == 'COMPLETED' && _completedDateTime != null
                      ? _formatDateTime(_completedDateTime!)
                      : _statusLabel(_currentStatus),
                  _currentStatus == 'COMPLETED'
                      ? Icons.check_circle_outline
                      : Icons.pending_outlined,
                  _getStatusColor(_currentStatus),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Notes Section with Edit Capability
          _buildNotesSection(),

          const SizedBox(height: 28),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor(_currentStatus).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(_currentStatus).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: DropdownButton<String>(
        value: _statusOptions.contains(_currentStatus) ? _currentStatus : null,
        isDense: true,
        underline: Container(),
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: _getStatusColor(_currentStatus),
          fontWeight: FontWeight.w600,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down,
          size: 16,
          color: _getStatusColor(_currentStatus),
        ),
        items: _statusOptions.map((status) {
          return DropdownMenuItem<String>(
            value: status,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _statusLabel(status),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: _onStatusChanged,
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String value, Color color) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF8159A8)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF8159A8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.note_outlined, size: 16, color: Color(0xFF8159A8)),
            const SizedBox(width: 8),
            const Text(
              'Notes',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF8159A8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () async {
                final result = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    final controller = TextEditingController(text: _taskNotes);
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Text('Edit Notes'),
                      content: TextField(
                        controller: controller,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Add your notes here...',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(context, controller.text),
                          child: const Text('Save'),
                        ),
                      ],
                    );
                  },
                );
                if (result != null) {
                  setState(() {
                    _taskNotes = result;
                  });
                }
              },
              icon: const Icon(
                Icons.edit_outlined,
                size: 16,
                color: Color(0xFF8159A8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
          ),
          child: Text(
            _taskNotes.isEmpty ? 'No notes added yet.' : _taskNotes,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: _taskNotes.isEmpty
                  ? const Color(0xFF9CA3AF)
                  : const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  void _showNotesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Edit Notes',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF1A1A1A),
            ),
          ),
          content: TextField(
            controller: _notesController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Add your notes here...',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF8159A8), width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _taskNotes = _notesController.text;
                });
                _saveTaskData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notes updated successfully'),
                    backgroundColor: Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8159A8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTagsSection(Map<String, dynamic> task) {
    // Try to get tags as a List<String> or comma-separated string
    List<String> tags = [];
    if (task['tags'] is List) {
      tags = List<String>.from(task['tags']);
    } else if (task['tags'] is String) {
      tags = (task['tags'] as String).split(',').map((e) => e.trim()).toList();
    } else if (task['category'] != null) {
      tags = [task['category'].toString()];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 16,
              color: Color(0xFF8159A8),
            ),
            SizedBox(width: 8),
            Text(
              'Tags',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF8159A8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        tags.isEmpty
            ? const Text(
                'No tags',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags
                    .map(
                      (tag) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8159A8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF8159A8).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Color(0xFF8159A8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton.icon(
              onPressed: _editTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8159A8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text(
                'Edit Task',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton.icon(
              onPressed: _deleteTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text(
                'Delete Task',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _editTask() {
    // Add smooth transition animation
    Navigator.pushNamed(
      context,
      '/edit_task',
      arguments: {
        'title': 'Dashboard Analytics Implementation',
        'description':
            'Implement analytics dashboard with real-time data visualization and reporting features.',
        'tags': ['Analytics', 'Dashboard', 'Frontend', 'React', 'Chart.js'],
        'date': 'Today, Jul 17',
        'notes': _taskNotes,
        'status': _currentStatus,
      },
    );
  }

  void _deleteTask() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 200),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(24),
            title: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFEF4444),
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Delete Task',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            content: const Text(
              'Are you sure you want to delete this task? This action cannot be undone.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task deleted successfully'),
                      backgroundColor: Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
