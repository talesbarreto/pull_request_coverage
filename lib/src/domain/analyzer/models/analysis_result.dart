class AnalysisResult {
  final int linesShouldBeTested;
  final int linesMissingTests;
  final int untestedIgnoredLines;
  final double coverageRate;

  const AnalysisResult({
    required this.linesShouldBeTested,
    required this.linesMissingTests,
    required this.untestedIgnoredLines,
  }) : coverageRate = 1 - (linesMissingTests / linesShouldBeTested);
}
