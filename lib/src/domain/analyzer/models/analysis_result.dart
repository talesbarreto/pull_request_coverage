class AnalysisResult {
  final int linesThatShouldBeTested;
  final int linesMissingTests;
  final int untestedIgnoredLines;
  final double coverageRate;

  const AnalysisResult({
    required this.linesThatShouldBeTested,
    required this.linesMissingTests,
    required this.untestedIgnoredLines,
  }) : coverageRate = 1 - (linesMissingTests / linesThatShouldBeTested);
}
