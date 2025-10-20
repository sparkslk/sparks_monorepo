import 'package:flutter/material.dart';
import '../../models/adhd_quiz_result.dart';

class AdhdQuizResultsScreen extends StatelessWidget {
  const AdhdQuizResultsScreen({super.key});

  // App theme colors
  final Color primaryColor = const Color(0xFF8159A8);
  final Color backgroundColor = const Color(0xFFFAFAFA);
  final Color textColor = const Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? resultData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (resultData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('No results data available'),
        ),
      );
    }

    final result = AdhdQuizResult.fromJson(resultData);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Assessment Results',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section with ADHD type
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getTypeColor(result.adhdType),
                    _getTypeColor(result.adhdType).withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _getTypeIcon(result.adhdType),
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    result.adhdTypeDisplay,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Severity: ${result.severityLevel}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Score breakdown
                  _buildSection(
                    title: 'Score Breakdown',
                    icon: Icons.analytics_outlined,
                    child: Column(
                      children: [
                        _buildScoreRow(
                          'Inattention Score',
                          result.inattentionScore,
                          36,
                          Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        _buildScoreRow(
                          'Hyperactivity-Impulsivity Score',
                          result.hyperactivityScore,
                          36,
                          Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        _buildScoreRow(
                          'Total Score',
                          result.totalScore,
                          72,
                          Colors.purple,
                        ),
                        const SizedBox(height: 16),
                        _buildScoreLegend(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Interpretation
                  _buildSection(
                    title: 'What This Means',
                    icon: Icons.psychology_outlined,
                    child: Text(
                      result.interpretation,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        height: 1.6,
                        color: textColor.withOpacity(0.9),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Recommendations
                  if (result.recommendations.isNotEmpty)
                    _buildSection(
                      title: 'Recommendations',
                      icon: Icons.checklist_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: result.recommendations
                            .map((rec) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(
                                            top: 6, right: 12),
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          rec,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 15,
                                            height: 1.5,
                                            color: textColor.withOpacity(0.9),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Important disclaimer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Important Disclaimer',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'This screening tool is for educational purposes only and is NOT a diagnostic tool. Only a qualified healthcare professional (Clinical Psychologist, Psychiatrist, or Paediatrician) can accurately diagnose ADHD. If your results suggest ADHD, please consult a healthcare provider for a comprehensive evaluation.',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/dashboard',
                          (route) => false,
                        );
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
                        'Continue to Dashboard',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to therapist selection
                        Navigator.pushNamed(context, '/choose_therapist');
                      },
                      icon: const Icon(Icons.person_search),
                      label: const Text('Find a Therapist'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: primaryColor),
                        foregroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildScoreRow(
      String label, int score, int maxScore, Color color) {
    final percentage = (score / maxScore * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            Text(
              '$score / $maxScore',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: score / maxScore,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Score Interpretation:',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildLegendItem('0-13', 'Low likelihood', Colors.green),
          _buildLegendItem('14-23', 'Possible ADHD', Colors.yellow.shade700),
          _buildLegendItem('24-35', 'High likelihood', Colors.orange),
          _buildLegendItem('36+', 'Very high likelihood', Colors.red),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String range, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$range points - $label',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: textColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'PREDOMINANTLY_INATTENTIVE':
        return const Color(0xFF8159A8); // Primary purple
      case 'PREDOMINANTLY_HYPERACTIVE_IMPULSIVE':
        return Colors.orange.shade700;
      case 'COMBINED':
        return const Color(0xFF6B4C9A); // Darker purple
      case 'LOW_LIKELIHOOD':
        return Colors.green.shade700;
      case 'NO_ADHD':
        return Colors.teal.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'PREDOMINANTLY_INATTENTIVE':
        return Icons.psychology_outlined;
      case 'PREDOMINANTLY_HYPERACTIVE_IMPULSIVE':
        return Icons.directions_run_outlined;
      case 'COMBINED':
        return Icons.merge_type_outlined;
      case 'LOW_LIKELIHOOD':
        return Icons.check_circle_outline;
      case 'NO_ADHD':
        return Icons.info_outline;
      default:
        return Icons.help_outline;
    }
  }
}
