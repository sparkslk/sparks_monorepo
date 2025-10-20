class AdhdQuizResult {
  final String id;
  final int inattentionScore;
  final int hyperactivityScore;
  final int totalScore;
  final String adhdType;
  final String interpretation;
  final List<String> recommendations;
  final DateTime? completedAt;

  AdhdQuizResult({
    required this.id,
    required this.inattentionScore,
    required this.hyperactivityScore,
    required this.totalScore,
    required this.adhdType,
    required this.interpretation,
    required this.recommendations,
    this.completedAt,
  });

  factory AdhdQuizResult.fromJson(Map<String, dynamic> json) {
    return AdhdQuizResult(
      id: json['id'] as String? ?? '',
      inattentionScore: json['inattentionScore'] as int? ?? 0,
      hyperactivityScore: json['hyperactivityScore'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      adhdType: json['adhdType'] as String? ?? 'UNKNOWN',
      interpretation: json['interpretation'] as String? ?? '',
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  String get adhdTypeDisplay {
    switch (adhdType) {
      case 'PREDOMINANTLY_INATTENTIVE':
        return 'Predominantly Inattentive Type';
      case 'PREDOMINANTLY_HYPERACTIVE_IMPULSIVE':
        return 'Predominantly Hyperactive-Impulsive Type';
      case 'COMBINED':
        return 'Combined Type';
      case 'LOW_LIKELIHOOD':
        return 'Low Likelihood of ADHD';
      case 'NO_ADHD':
        return 'Below Diagnostic Threshold';
      default:
        return 'Unknown';
    }
  }

  String get severityLevel {
    if (totalScore < 14) return 'Low';
    if (totalScore < 24) return 'Possible';
    if (totalScore < 36) return 'High';
    return 'Very High';
  }
}
