class AdhdQuizResponse {
  final String sessionId;
  final Map<String, String> responses; // {q1: "D", q2: "E", ...}

  AdhdQuizResponse({
    required this.sessionId,
    required this.responses,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'responses': responses,
    };
  }

  factory AdhdQuizResponse.fromJson(Map<String, dynamic> json) {
    return AdhdQuizResponse(
      sessionId: json['sessionId'] as String,
      responses: Map<String, String>.from(json['responses'] as Map),
    );
  }
}
