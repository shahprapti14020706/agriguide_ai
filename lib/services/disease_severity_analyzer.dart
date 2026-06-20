class DiseaseSeverityAnalyzer {
  DiseaseSeverityResult analyze({
    required double confidenceScore,
    required String plantPart,
  }) {
    if (confidenceScore >= 0.82) {
      return DiseaseSeverityResult(
        level: 'High',
        advice:
            'The $plantPart symptoms may need urgent field inspection and quick corrective action.',
      );
    }

    if (confidenceScore >= 0.62) {
      return DiseaseSeverityResult(
        level: 'Moderate',
        advice:
            'Monitor spread on the $plantPart closely and begin stage-appropriate treatment.',
      );
    }

    return DiseaseSeverityResult(
      level: 'Low',
      advice:
          'Symptoms on the $plantPart appear limited. Continue observation and preventive care.',
    );
  }
}

class DiseaseSeverityResult {
  const DiseaseSeverityResult({
    required this.level,
    required this.advice,
  });

  final String level;
  final String advice;
}
