import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';
import '../../widgets/therapy_appbar.dart';
import '../../services/api_service.dart';
import 'dart:convert';
import '../../services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewTasksPage extends StatefulWidget {
  @override
  _NewTasksPageState createState() => _NewTasksPageState();
}

class _NewTasksPageState extends State<NewTasksPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _customCategoryController =
      TextEditingController();

  String selectedPriority = 'High';
  String selectedCategory = 'Study';
  bool isAlertEnabled = false;
  DateTime? selectedDate;
  List<String> customCategories = [];

  final Color primaryColor = Color(0xFF8159FF);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const TherapyAppBar(
        title: 'Add Task',
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Tasks',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 32),
                _buildTaskTitleField(),
                SizedBox(height: 20),
                _buildPriorityDropdown(),
                SizedBox(height: 20),
                _buildDateField(),
                SizedBox(height: 20),
                _buildDescriptionField(),
                SizedBox(height: 32),
                _buildCategorySection(),
                SizedBox(height: 32),
                _buildAlertSection(),
                SizedBox(height: 40),
                _buildCreateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _titleController,
        decoration: InputDecoration(
          hintText: 'Task Title',
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPriority,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          onChanged: (String? newValue) {
            setState(() {
              selectedPriority = newValue!;
            });
          },
          items: ['High', 'Medium', 'Low'].map<DropdownMenuItem<String>>((
            String value,
          ) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(value, style: TextStyle(fontSize: 16)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: InkWell(
        onTap: () => _selectDate(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedDate != null
                      ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                      : 'Select Date',
                  style: TextStyle(
                    fontSize: 16,
                    color: selectedDate != null
                        ? Colors.black
                        : Colors.grey[500],
                  ),
                ),
              ),
              Icon(Icons.calendar_today, color: primaryColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Add your task details...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildCategorySection() {
    List<String> defaultCategories = ['Study', 'Family', 'Hobbies', 'School'];
    List<String> allCategories = [...defaultCategories, ...customCategories];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            TextButton(
              onPressed: _showAddCategoryDialog,
              child: Text(
                'Add Custom',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: allCategories
              .map((category) => _buildCategoryChip(category))
              .toList(),
        ),
      ],
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Custom Category'),
          content: TextField(
            controller: _customCategoryController,
            decoration: InputDecoration(
              hintText: 'Enter category name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _customCategoryController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_customCategoryController.text.isNotEmpty) {
                  setState(() {
                    customCategories.add(_customCategoryController.text);
                    selectedCategory = _customCategoryController.text;
                  });
                  _customCategoryController.clear();
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryChip(String category) {
    bool isSelected = selectedCategory == category;
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      child: FilterChip(
        label: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            selectedCategory = category;
          });
        },
        selectedColor: primaryColor,
        backgroundColor: Colors.grey[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildAlertSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Get alert for this task',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        Switch(
          value: isAlertEnabled,
          onChanged: (bool value) {
            setState(() {
              isAlertEnabled = value;
            });
          },
          activeColor: primaryColor,
          activeTrackColor: primaryColor.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // Handle create task action
          _handleCreateTask();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Create Task',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _handleCreateTask() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final priorityMap = {'High': 3, 'Medium': 2, 'Low': 1};
    final priority = priorityMap[selectedPriority] ?? 1;
    // Add 5 hours and 30 minutes to the selected date
    final dueDate = selectedDate != null
        ? selectedDate!.add(Duration(hours: 6, minutes: 10)).toString()
        : null;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task title is required.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await ApiService.authenticatedRequest(
        'POST',
        '/api/mobile/task',
        body: {
          'title': title,
          'description': description.isNotEmpty ? description : null,
          'priority': priority,
          'category': selectedCategory,
          'dueDate': dueDate,
          // Optionally add: 'instructions', 'isRecurring', 'recurringPattern', 'sessionid', 'category', 'alertEnabled'
        },
      );
      Navigator.of(context, rootNavigator: true).pop(); // Close loading
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      if (response.statusCode == 201 && data['success'] == true) {
        final taskId = data['task']?['id'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task created successfully!'),
            backgroundColor: primaryColor,
          ),
        );

        // Save alert setting to SharedPreferences and schedule 8PM notification
        if (isAlertEnabled && taskId != null && selectedDate != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('task_alert_$taskId', true);

          // Schedule 8PM notification for the task
          await NotificationService.I.scheduleTaskReminder(
            taskId: taskId.toString(),
            title: title,
            dueDate: selectedDate!,
          );
        }

        // Refresh daily incomplete schedule with newest task set (fire and forget)
        NotificationService.I.scheduleDailyIncompleteTasksCheck();
        Navigator.pop(context); // Go back to previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Failed to create task.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
