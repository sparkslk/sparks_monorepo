import 'package:flutter/material.dart';
import 'dart:async';
import '../../widgets/navbar.dart';
import 'dart:math' as math;

class PomodoroTimerPage extends StatefulWidget {
  @override
  _PomodoroTimerPageState createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  Timer? _timer;
  int _totalSeconds = 25 * 60; // Default 25 minutes
  int _currentSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isPaused = false;
  
  // Custom time selection
  int _selectedMinutes = 25;
  int _selectedSeconds = 0;
  bool _isCustomTime = false;

  final Color primaryColor = Color(0xFF8159FF);

  // Predefined Pomodoro presets
  final List<Map<String, dynamic>> _presets = [
    {'name': 'Classic Pomodoro', 'minutes': 25, 'seconds': 0},
    {'name': 'Short Break', 'minutes': 5, 'seconds': 0},
    {'name': 'Long Break', 'minutes': 15, 'seconds': 0},
    {'name': 'Deep Work', 'minutes': 50, 'seconds': 0},
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: Duration(milliseconds: 60000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isPaused) {
      // Resume timer
      setState(() {
        _isRunning = true;
        _isPaused = false;
      });
    } else {
      // Start new timer
      if (_isCustomTime) {
        _totalSeconds = (_selectedMinutes * 60) + _selectedSeconds;
        _currentSeconds = _totalSeconds;
      }
      setState(() {
        _isRunning = true;
        _isPaused = false;
      });
    }

    _pulseController.repeat(reverse: true);
    _rotationController.repeat();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_currentSeconds > 0) {
        setState(() {
          _currentSeconds--;
        });
      } else {
        _completeTimer();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _pulseController.stop();
    _rotationController.stop();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _currentSeconds = _totalSeconds;
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _pulseController.stop();
    _rotationController.stop();
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
  }

  void _completeTimer() {
    _timer?.cancel();
    _pulseController.stop();
    _rotationController.stop();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });
    
    // Show completion dialog
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('🎉 Timer Completed!'),
          content: Text('Great job! Your Pomodoro session is complete.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetTimer();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              child: Text('Start New Session', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _resetTimer() {
    setState(() {
      _currentSeconds = _totalSeconds;
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double _getProgress() {
    return _totalSeconds > 0 ? (_totalSeconds - _currentSeconds) / _totalSeconds : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pomodoro Timer',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            children: [
              SizedBox(height: 40),
              _buildTimerCircle(),
              SizedBox(height: 60),
              _buildControlButtons(),
              SizedBox(height: 40),
              _buildPresetButtons(),
              SizedBox(height: 30),
              _buildCustomTimeSelector(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerCircle() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isRunning ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 280,
            height: 280,
            child: Stack(
              children: [
                // Background circle
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[50],
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                // Progress circle
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Container(
                        width: 280,
                        height: 280,
                        child: CircularProgressIndicator(
                          value: _getProgress(),
                          strokeWidth: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      ),
                    );
                  },
                ),
                // Time text
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(_currentSeconds),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _isRunning ? 'Focus Time' : _isPaused ? 'Paused' : 'Ready to Start',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Stop button
        AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isRunning || _isPaused ? Colors.red.withOpacity(0.1) : Colors.grey[100],
            border: Border.all(
              color: _isRunning || _isPaused ? Colors.red : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: IconButton(
            onPressed: (_isRunning || _isPaused) ? _stopTimer : null,
            icon: Icon(
              Icons.stop,
              size: 30,
              color: _isRunning || _isPaused ? Colors.red : Colors.grey,
            ),
          ),
        ),
        // Start/Pause button
        AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            onPressed: _isRunning ? _pauseTimer : _startTimer,
            icon: Icon(
              _isRunning ? Icons.pause : Icons.play_arrow,
              size: 35,
              color: Colors.white,
            ),
          ),
        ),
        // Reset button
        AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[100],
            border: Border.all(
              color: Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: IconButton(
            onPressed: _resetTimer,
            icon: Icon(
              Icons.refresh,
              size: 30,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Presets',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _presets.map((preset) => _buildPresetChip(preset)).toList(),
        ),
      ],
    );
  }

  Widget _buildPresetChip(Map<String, dynamic> preset) {
    bool isSelected = !_isCustomTime && 
                     _totalSeconds == (preset['minutes'] * 60 + preset['seconds']) &&
                     !_isRunning && !_isPaused;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      child: FilterChip(
        label: Text(
          preset['name'],
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_isRunning || _isPaused) ? null : (bool selected) {
          if (selected) {
            setState(() {
              _totalSeconds = preset['minutes'] * 60 + preset['seconds'];
              _currentSeconds = _totalSeconds;
              _isCustomTime = false;
            });
          }
        },
        selectedColor: primaryColor,
        backgroundColor: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildCustomTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Time',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeInput('Minutes', _selectedMinutes, 0, 99, (value) {
                    setState(() {
                      _selectedMinutes = value;
                    });
                  }),
                  Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  _buildTimeInput('Seconds', _selectedSeconds, 0, 59, (value) {
                    setState(() {
                      _selectedSeconds = value;
                    });
                  }),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isRunning || _isPaused) ? null : () {
                    setState(() {
                      _totalSeconds = (_selectedMinutes * 60) + _selectedSeconds;
                      _currentSeconds = _totalSeconds;
                      _isCustomTime = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Set Custom Time',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInput(String label, int value, int min, int max, Function(int) onChanged) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 32,
                child: IconButton(
                  onPressed: value < max ? () => onChanged(value + 1) : null,
                  icon: Icon(Icons.keyboard_arrow_up, color: primaryColor, size: 20),
                  padding: EdgeInsets.zero,
                ),
              ),
              Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Text(
                    value.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
              Container(
                height: 32,
                child: IconButton(
                  onPressed: value > min ? () => onChanged(value - 1) : null,
                  icon: Icon(Icons.keyboard_arrow_down, color: primaryColor, size: 20),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
