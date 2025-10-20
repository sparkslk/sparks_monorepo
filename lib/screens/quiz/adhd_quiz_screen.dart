import 'package:flutter/material.dart';
import '../../data/adhd_quiz_data.dart';
import '../../models/adhd_quiz_question.dart';
import '../../models/adhd_quiz_response.dart';
import '../../services/api_service.dart';

class AdhdQuizScreen extends StatefulWidget {
  const AdhdQuizScreen({super.key});

  @override
  State<AdhdQuizScreen> createState() => _AdhdQuizScreenState();
}

class _AdhdQuizScreenState extends State<AdhdQuizScreen> {
  int _currentQuestionIndex = 0;
  final Map<String, String> _responses = {};
  bool _isSubmitting = false;
  bool _showInstructions = true;

  // App theme colors
  final Color primaryColor = const Color(0xFF8159A8);
  final Color backgroundColor = const Color(0xFFFAFAFA);
  final Color textColor = const Color(0xFF1A1A1A);

  AdhdQuizQuestion get _currentQuestion =>
      adhdQuizQuestions[_currentQuestionIndex];

  double get _progress =>
      (_currentQuestionIndex + 1) / adhdQuizQuestions.length;

  bool get _canGoNext =>
      _responses.containsKey('q${_currentQuestion.id}') ||
      _currentQuestionIndex == adhdQuizQuestions.length - 1;

  bool get _isLastQuestion =>
      _currentQuestionIndex == adhdQuizQuestions.length - 1;

  void _selectOption(String value) {
    setState(() {
      _responses['q${_currentQuestion.id}'] = value;
    });
  }

  void _goToNext() {
    if (!_responses.containsKey('q${_currentQuestion.id}')) {
      _showErrorDialog('Please select an option before continuing');
      return;
    }

    if (_isLastQuestion) {
      _submitQuiz();
    } else {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _goToPrevious() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _submitQuiz() async {
    // Validate all questions answered
    final unanswered = <int>[];
    for (int i = 1; i <= 20; i++) {
      if (!_responses.containsKey('q$i')) {
        unanswered.add(i);
      }
    }

    if (unanswered.isNotEmpty) {
      _showErrorDialog(
          'Please answer all questions before submitting.\nUnanswered: Questions ${unanswered.join(', ')}');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final sessionId = 'session-${DateTime.now().millisecondsSinceEpoch}';
      final quizResponse = AdhdQuizResponse(
        sessionId: sessionId,
        responses: _responses,
      );

      final result = await ApiService.submitAdhdQuiz(quizResponse.toJson());

      setState(() {
        _isSubmitting = false;
      });

      if (result['success'] == true && mounted) {
        // Navigate to results screen
        Navigator.pushReplacementNamed(
          context,
          '/adhd_quiz_results',
          arguments: result['result'],
        );
      } else {
        _showErrorDialog(
            result['message'] ?? 'Failed to submit quiz. Please try again.');
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showErrorDialog('An error occurred: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text(
            'Your progress will not be saved. Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit quiz
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showInstructions) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'ADHD Assessment',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.close, color: textColor),
            onPressed: _showExitConfirmation,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ADHD Screening Quiz',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F5FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: primaryColor, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Instructions',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      quizInstructions,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        height: 1.5,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange.shade700, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This quiz takes approximately 5-10 minutes to complete. Please ensure you have enough time before starting.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showInstructions = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Start Assessment',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        _showExitConfirmation();
        return false;
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Question ${_currentQuestionIndex + 1} of 20',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.close, color: textColor),
            onPressed: _showExitConfirmation,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
        ),
        body: _isSubmitting
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Submitting your responses...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section header
                          if (_currentQuestion.category == 'inattention' &&
                              _currentQuestionIndex == 0)
                            _buildSectionHeader('Section A: Inattention Symptoms'),
                          if (_currentQuestion.category == 'hyperactivity' &&
                              _currentQuestionIndex == 9)
                            _buildSectionHeader(
                                'Section B: Hyperactivity-Impulsivity Symptoms'),
                          if (_currentQuestion.category == 'context' &&
                              _currentQuestionIndex == 18)
                            _buildSectionHeader(
                                'Section C: Impairment and Context'),

                          const SizedBox(height: 16),

                          // Question text
                          Text(
                            _currentQuestion.question,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: textColor,
                            ),
                          ),

                          // Note if present
                          if (_currentQuestion.note != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.lightbulb_outline,
                                      color: Colors.grey.shade600, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _currentQuestion.note!,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: textColor.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Options
                          ..._currentQuestion.options.map((option) {
                            final isSelected = _responses['q${_currentQuestion.id}'] == option.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: InkWell(
                                onTap: () => _selectOption(option.value),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFF8F5FF)
                                        : Colors.white,
                                    border: Border.all(
                                      color: isSelected
                                          ? primaryColor
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: primaryColor.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? primaryColor
                                              : Colors.white,
                                          border: Border.all(
                                            color: isSelected
                                                ? primaryColor
                                                : Colors.grey.shade400,
                                            width: 2,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check,
                                                size: 16,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          option.label,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 16,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? primaryColor
                                                : textColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),

                  // Navigation buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (_currentQuestionIndex > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _goToPrevious,
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Colors.grey.shade400),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Previous',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                        Expanded(
                          flex: _currentQuestionIndex == 0 ? 1 : 1,
                          child: ElevatedButton(
                            onPressed: _canGoNext ? _goToNext : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              _isLastQuestion ? 'Submit' : 'Next',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
