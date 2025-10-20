import '../models/adhd_quiz_question.dart';

// Standard options for questions 1-18 (frequency scale)
final List<AdhdQuizOption> frequencyOptions = [
  AdhdQuizOption(value: 'A', label: 'Never', score: 0),
  AdhdQuizOption(value: 'B', label: 'Rarely', score: 1),
  AdhdQuizOption(value: 'C', label: 'Sometimes', score: 2),
  AdhdQuizOption(value: 'D', label: 'Often', score: 3),
  AdhdQuizOption(value: 'E', label: 'Very Often', score: 4),
];

// All 20 ADHD screening questions based on Quiz.md
final List<AdhdQuizQuestion> adhdQuizQuestions = [
  // SECTION A: Inattention Symptoms (Q1-Q9)
  AdhdQuizQuestion(
    id: 1,
    question:
        'How often do you fail to give close attention to details or make careless mistakes in your work, schoolwork, or other activities?',
    category: 'inattention',
    options: frequencyOptions,
    note: 'Based on how you have felt over the past 6 months',
  ),
  AdhdQuizQuestion(
    id: 2,
    question:
        'How often do you have difficulty sustaining attention during tasks, meetings, lectures, or conversations?',
    category: 'inattention',
    options: frequencyOptions,
  ),
  AdhdQuizQuestion(
    id: 3,
    question:
        'How often do you find that you don\'t seem to listen when spoken to directly (your mind seems elsewhere)?',
    category: 'inattention',
    options: frequencyOptions,
  ),
  AdhdQuizQuestion(
    id: 4,
    question:
        'How often do you fail to follow through on instructions and fail to finish work, chores, or duties (you start tasks but quickly lose focus)?',
    category: 'inattention',
    options: frequencyOptions,
  ),
  AdhdQuizQuestion(
    id: 5,
    question:
        'How often do you have trouble organizing tasks and activities (such as managing sequential tasks, keeping materials organized, managing time, or meeting deadlines)?',
    category: 'inattention',
    options: frequencyOptions,
  ),
  AdhdQuizQuestion(
    id: 6,
    question:
        'How often do you avoid, dislike, or are reluctant to engage in tasks that require sustained mental effort (such as preparing reports, completing forms, or reviewing lengthy papers)?',
    category: 'inattention',
    options: frequencyOptions,
  ),
  AdhdQuizQuestion(
    id: 7,
    question:
        'How often do you lose things necessary for tasks or activities (such as keys, wallet, mobile phone, paperwork, eyeglasses, or important documents)?',
    category: 'inattention',
    options: frequencyOptions,
  ),
  AdhdQuizQuestion(
    id: 8,
    question:
        'How often are you easily distracted by external stimuli or unrelated thoughts?',
    category: 'inattention',
    options: frequencyOptions,
  ),
  AdhdQuizQuestion(
    id: 9,
    question:
        'How often are you forgetful in daily activities (such as returning calls, paying bills, keeping appointments, or doing chores)?',
    category: 'inattention',
    options: frequencyOptions,
  ),

  // SECTION B: Hyperactivity-Impulsivity Symptoms (Q10-Q18)
  AdhdQuizQuestion(
    id: 10,
    question: 'How often do you fidget with your hands or feet, or squirm in your seat?',
    category: 'hyperactivity',
    options: frequencyOptions,
  ),
  AdhdQuizQuestion(
    id: 11,
    question:
        'How often do you leave your seat in situations when remaining seated is expected (such as during meetings, lectures, or at work)?',
    category: 'hyperactivity',
    options: frequencyOptions,
  ),
  AdhdQuizQuestion(
    id: 12,
    question:
        'How often do you feel restless or run about/climb excessively in situations where it is inappropriate? (In adults, this may be limited to subjective feelings of restlessness)',
    category: 'hyperactivity',
    options: frequencyOptions,
  ),
  AdhdQuizQuestion(
    id: 13,
    question:
        'How often do you have difficulty engaging in leisure activities or doing things quietly?',
    category: 'hyperactivity',
    options: frequencyOptions,
  ),
  AdhdQuizQuestion(
    id: 14,
    question:
        'How often are you "on the go," acting as if "driven by a motor" (constantly active or uncomfortable being still for extended periods)?',
    category: 'hyperactivity',
    options: frequencyOptions,
  ),
  AdhdQuizQuestion(
    id: 15,
    question:
        'How often do you talk excessively or find yourself talking too much in social situations?',
    category: 'hyperactivity',
    options: frequencyOptions,
  ),
  AdhdQuizQuestion(
    id: 16,
    question:
        'How often do you blurt out answers before questions have been completed, or finish other people\'s sentences?',
    category: 'hyperactivity',
    options: frequencyOptions,
  ),
  AdhdQuizQuestion(
    id: 17,
    question:
        'How often do you have difficulty waiting your turn in situations that require turn-taking?',
    category: 'hyperactivity',
    options: frequencyOptions,
  ),
  AdhdQuizQuestion(
    id: 18,
    question:
        'How often do you interrupt or intrude on others (such as butting into conversations, games, or activities without being invited)?',
    category: 'hyperactivity',
    options: frequencyOptions,
  ),

  // SECTION C: Impairment and Context Questions (Q19-Q20)
  AdhdQuizQuestion(
    id: 19,
    question:
        'Do these symptoms cause significant problems or impairment in at least TWO or more areas of your life (such as work/school, home, social relationships, or daily functioning)?',
    category: 'context',
    options: [
      AdhdQuizOption(
        value: 'A',
        label: 'No impairment - symptoms don\'t really affect my life',
        score: 0,
      ),
      AdhdQuizOption(
        value: 'B',
        label: 'Mild impairment - some minor difficulties but manage well overall',
        score: 1,
      ),
      AdhdQuizOption(
        value: 'C',
        label: 'Moderate impairment - noticeable problems that affect my daily functioning',
        score: 2,
      ),
      AdhdQuizOption(
        value: 'D',
        label: 'Severe impairment - significant problems that seriously impact my ability to function',
        score: 3,
      ),
    ],
    note: 'This question helps determine if symptoms cause significant impairment',
  ),
  AdhdQuizQuestion(
    id: 20,
    question:
        'Thinking back to your childhood (before age 12), did you experience similar attention, hyperactivity, or impulsivity problems?',
    category: 'context',
    options: [
      AdhdQuizOption(
        value: 'A',
        label: 'No, these symptoms only started in my teenage years or adulthood',
        score: 0,
      ),
      AdhdQuizOption(
        value: 'B',
        label: 'Unsure, I don\'t remember clearly',
        score: 1,
      ),
      AdhdQuizOption(
        value: 'C',
        label: 'Yes, I had some of these symptoms but they were mild',
        score: 2,
      ),
      AdhdQuizOption(
        value: 'D',
        label: 'Yes, I definitely had these symptoms and they caused problems',
        score: 3,
      ),
    ],
    note: 'ADHD symptoms must be present before age 12 for a diagnosis',
  ),
];

// Section titles for UI organization
const Map<String, String> sectionTitles = {
  'inattention': 'Section A: Inattention Symptoms',
  'hyperactivity': 'Section B: Hyperactivity-Impulsivity Symptoms',
  'context': 'Section C: Impairment and Context',
};

// Instructions text
const String quizInstructions = '''
Please answer each question based on how you have felt and conducted yourself over the past 6 months. Select the option that best describes the frequency of each behavior.

IMPORTANT DISCLAIMER: This quiz is for educational and screening purposes only. It is NOT a diagnostic tool. Only a qualified healthcare professional (Clinical Psychologist, Psychiatrist, or Paediatrician) can accurately diagnose ADHD. If you score positively on this screening tool, please consult a healthcare provider for a comprehensive evaluation.
''';
