class AdhdQuizOption {
  final String value;
  final String label;
  final int score;

  AdhdQuizOption({
    required this.value,
    required this.label,
    required this.score,
  });
}

class AdhdQuizQuestion {
  final int id;
  final String question;
  final String category; // "inattention" | "hyperactivity" | "context"
  final List<AdhdQuizOption> options;
  final String? note; // Additional context for the question

  AdhdQuizQuestion({
    required this.id,
    required this.question,
    required this.category,
    required this.options,
    this.note,
  });
}
